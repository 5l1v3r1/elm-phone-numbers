module PhoneNumberTest exposing (suite)

import Expect exposing (Expectation)
import PhoneNumber
import PhoneNumber.Countries exposing (..)
import Test exposing (..)


norwegianConfig =
    { countries = [ countryNO ]
    , types = PhoneNumber.anyType
    , defaultCountry = Nothing
    }


suite : Test
suite =
    describe "PhoneNumbersTest API"
        [ describe "valid"
            [ test "Norwegian local number" <|
                \_ ->
                    PhoneNumber.valid norwegianConfig "40612345"
                        |> Expect.true "Not a match for norwegian number"
            , test "Norwegian local number with international prefix" <|
                \_ ->
                    PhoneNumber.valid norwegianConfig "004740612345"
                        |> Expect.true "Not a match for norwegian number with international prefix"
            , test "Norwegian local number with + prefix" <|
                \_ ->
                    PhoneNumber.valid norwegianConfig "+4740612345"
                        |> Expect.true "Not a match for norwegian number with + prefix"
            ]
        , describe "type matches"
            [ test "Finds local number" <|
                \_ ->
                    PhoneNumber.matches norwegianConfig "40612354"
                        |> Expect.equalLists [ ( countryNO, [ PhoneNumber.Mobile ] ) ]
            , test "Finds local number even without types" <|
                \_ ->
                    PhoneNumber.matches { norwegianConfig | types = [] } "40612354"
                        |> Expect.equalLists [ ( countryNO, [] ) ]
            , test "But only if it matches the general pattern" <|
                \_ ->
                    PhoneNumber.matches { norwegianConfig | types = [] } "12345"
                        |> Expect.equalLists []
            ]
        , describe "default country"
            [ test "When it isnt set, it tries every config it can" <|
                \_ ->
                    PhoneNumber.matches { norwegianConfig | countries = [ countryNO, countrySE ] } "40612354"
                        |> Expect.equalLists
                            [ ( countryNO, [ PhoneNumber.Mobile ] )
                            , ( countrySE, [ PhoneNumber.FixedLine ] )
                            ]
            , test "When set, every localized number is treated as if it belongs to the default country" <|
                \_ ->
                    PhoneNumber.matches
                        { norwegianConfig
                            | countries = [ countryNO, countrySE ]
                            , defaultCountry = Just countryNO
                        }
                        "40612354"
                        |> Expect.equalLists [ ( countryNO, [ PhoneNumber.Mobile ] ) ]
            ]
        ]
