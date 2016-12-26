From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethtool: don't require CAP_NET_ADMIN for
 ETHTOOL_GLINKSETTINGS
Date: Mon, 26 Dec 2016 12:38:44 -0500 (EST)
Message-ID: <20161226.123844.592887879230573929.davem@davemloft.net>
References: <20161124095506.25791-1-mlichvar@redhat.com>
        <87tw9s311z.fsf@luffy.cx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: mlichvar@redhat.com, netdev@vger.kernel.org, decot@googlers.com
To: bernat@luffy.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53704 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754136AbcLZRis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 12:38:48 -0500
In-Reply-To: <87tw9s311z.fsf@luffy.cx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVmluY2VudCBCZXJuYXQgPGJlcm5hdEBsdWZmeS5jeD4NCkRhdGU6IFN1biwgMjUgRGVj
IDIwMTYgMDg6NDQ6NDAgKzAxMDANCg0KPiAg4p2mIDI0IG5vdmVtYnJlIDIwMTYgMTA6NTUgKzAx
MDAsIE1pcm9zbGF2IExpY2h2YXIgPG1saWNodmFyQHJlZGhhdC5jb20+wqA6DQo+IA0KPj4gVGhl
IEVUSFRPT0xfR0xJTktTRVRUSU5HUyBjb21tYW5kIGlzIGRlcHJlY2F0aW5nIHRoZSBFVEhUT09M
X0dTRVQNCj4+IGNvbW1hbmQgYW5kIGxpa2V3aXNlIGl0IHNob3VsZG4ndCByZXF1aXJlIHRoZSBD
QVBfTkVUX0FETUlODQo+PiBjYXBhYmlsaXR5Lg0KPiANCj4gQ291bGQgdGhpcyBwYXRjaCBiZSBw
dXNoZWQgdG8gc3RhYmxlIGJyYW5jaGVzIHRvbz8NCg0KU3VyZSwgcXVldWVkIHVwLg0K
