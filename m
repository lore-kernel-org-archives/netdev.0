From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] mq: preserve queue mapping with
 bonding and VLAN devices
Date: Sun, 28 Feb 2010 01:36:27 -0800 (PST)
Message-ID: <20100228.013627.200374267.davem@davemloft.net>
References: <272541267277332@webmail86.yandex.ru>
	<20100228.013311.242139140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: sysoleg@yandex.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031664Ab0B1JgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:36:09 -0500
In-Reply-To: <20100228.013311.242139140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogU3VuLCAyOCBG
ZWIgMjAxMCAwMTozMzoxMSAtMDgwMCAoUFNUKQ0KDQo+IEFwcGxpZWQsIHRoYW5rcyBPbGVnLg0K
DQpOZXZlcm1pbmQsIHRoaXMgcGF0Y2ggZG9lc24ndCBldmVuIGJ1aWxkIDotLyAgSSdtIHJldmVy
dGluZy4NCg0KSW4gZmlsZSBpbmNsdWRlZCBmcm9tIGluY2x1ZGUvbGludXgvbmV0ZmlsdGVyLmg6
NiwNCiAgICAgICAgICAgICAgICAgZnJvbSBpbmNsdWRlL25ldC9uZXRucy94X3RhYmxlcy5oOjUs
DQogICAgICAgICAgICAgICAgIGZyb20gaW5jbHVkZS9uZXQvbmV0X25hbWVzcGFjZS5oOjE4LA0K
ICAgICAgICAgICAgICAgICBmcm9tIGluY2x1ZGUvbGludXgvaW5pdF90YXNrLmg6MTMsDQogICAg
ICAgICAgICAgICAgIGZyb20gYXJjaC9zcGFyYy9rZXJuZWwvaW5pdF90YXNrLmM6NToNCmluY2x1
ZGUvbGludXgvc2tidWZmLmg6IEluIGZ1bmN0aW9uIKFza2JfZ2V0X3F1ZXVlX21hcHBpbmeiOg0K
aW5jbHVkZS9saW51eC9za2J1ZmYuaDoyMDIyOiBlcnJvcjogaW1wbGljaXQgZGVjbGFyYXRpb24g
b2YgZnVuY3Rpb24goXNrYl9yeF9xdWV1ZV9yZWNvcmRlZKINCmluY2x1ZGUvbGludXgvc2tidWZm
Lmg6IEF0IHRvcCBsZXZlbDoNCmluY2x1ZGUvbGludXgvc2tidWZmLmg6MjAzMDogZXJyb3I6IGNv
bmZsaWN0aW5nIHR5cGVzIGZvciChc2tiX3J4X3F1ZXVlX3JlY29yZGVkog0KaW5jbHVkZS9saW51
eC9za2J1ZmYuaDoyMDIyOiBub3RlOiBwcmV2aW91cyBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiCh
c2tiX3J4X3F1ZXVlX3JlY29yZGVkoiB3YXMgaGVyZQ0K
