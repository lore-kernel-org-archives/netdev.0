From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/7] flow_dissector: make local function static
Date: Tue, 10 Jan 2017 13:32:01 -0500 (EST)
Message-ID: <20170110.133201.2103096039977087636.davem@davemloft.net>
References: <20170110181816.18991-1-sthemmin@microsoft.com>
        <20170110181816.18991-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932800AbdAJScR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:32:17 -0500
In-Reply-To: <20170110181816.18991-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3BsdW1iZXIub3JnPg0KRGF0
ZTogVHVlLCAxMCBKYW4gMjAxNyAxMDoxODoxMCAtMDgwMA0KDQo+IEZpeCB3YXJuaW5nOiBubyBw
cmV2aW91cyBwcm90b3R5cGUgZm9yIKFza2JfZmxvd19nZXRfYmUxNqINCj4gRnVuY3Rpb24gaXMg
b25seSB1c2VkIGluIHRoaXMgZmlsZSwgbWFrZSBpdCBzdGF0aWMuDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBTdGVwaGVuIEhlbW1pbmdlciA8c3RoZW1taW5AbWljcm9zb2Z0LmNvbT4NCg0KRXJpYyBE
dW1hemV0IGFscmVhZHkgcG9zdGVkIGEgcGF0Y2ggd2hpY2ggZG9lcyB0aGlzLg0K
