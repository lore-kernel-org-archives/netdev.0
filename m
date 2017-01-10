From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: socket: Make unnecessarily global
 sockfs_setattr() static
Date: Tue, 10 Jan 2017 11:30:32 -0500 (EST)
Message-ID: <20170110.113032.1681128574789977926.davem@davemloft.net>
References: <20170110083051.753-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758068AbdAJQan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:30:43 -0500
In-Reply-To: <20170110083051.753-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9iaWFzIEtsYXVzZXIgPHRrbGF1c2VyQGRpc3RhbnouY2g+DQpEYXRlOiBUdWUsIDEw
IEphbiAyMDE3IDA5OjMwOjUxICswMTAwDQoNCj4gTWFrZSBzb2NrZnNfc2V0YXR0cigpIHN0YXRp
YyBhcyBpdCBpcyBub3QgdXNlZCBvdXRzaWRlIG9mIG5ldC9zb2NrZXQuYw0KPiANCj4gVGhpcyBm
aXhlcyB0aGUgZm9sbG93aW5nIEdDQyB3YXJuaW5nOg0KPiBuZXQvc29ja2V0LmM6NTM0OjU6IHdh
cm5pbmc6IG5vIHByZXZpb3VzIHByb3RvdHlwZSBmb3IgoXNvY2tmc19zZXRhdHRyoiBbLVdtaXNz
aW5nLXByb3RvdHlwZXNdDQo+IA0KPiBGaXhlczogODY3NDFlYzI1NDYyICgibmV0OiBjb3JlOiBB
ZGQgYSBVSUQgZmllbGQgdG8gc3RydWN0IHNvY2suIikNCj4gQ2M6IExvcmVuem8gQ29saXR0aSA8
bG9yZW56b0Bnb29nbGUuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBUb2JpYXMgS2xhdXNlciA8dGts
YXVzZXJAZGlzdGFuei5jaD4NCg0KQXBwbGllZCwgdGhhbmtzLg0K
