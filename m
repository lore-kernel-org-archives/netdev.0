From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] SUNRPC: Prevent kernel stack corruption on long values of flush
Date: Thu, 18 Oct 2012 09:34:57 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7050@saturn3.aculab.com>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com> <20120718173913.GA1298@fieldses.org> <20120718200049.GA17964@umich.edu> <20120718203304.GA18540@redhat.com> <20120718205510.GA18374@umich.edu> <507EF918.5030004@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Dave Jones" <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"Sasha Levin" <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Boaz Harrosh" <bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>, "Jim Rees" <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <507EF918.5030004-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAuLi4NCj4gbG9uZyBpcyBhbHdheXMgdGhlIHNhbWUgb3IgYmlnZ2VyIHRoZW4gYSBwb2ludGVy
DQo+IChBIHBvaW50ZXIgbXVzdCBhbHdheXMgZml0IGluIGEgbG9uZykNCj4gLi4uDQoNCkxpbnV4
IG1heSBtYWtlIHRoYXQgYXNzdW1wdGlvbiwgYnV0IGl0IGRvZXNuJ3QgaGF2ZQ0KdG8gYmUgdHJ1
ZS4gNjRiaXQgd2luZG93cyBzdGlsbCBoYXMgMzJiaXQgbG9uZy4NCkM5OSBpbnR0eXBlcy5oIGRl
ZmluZXMgW3VdaW50cHRyX3QgdG8gYmUgYW4gaW50ZWdyYWwgdHlwZQ0KdGhhdCBpcyBsYXJnZSBl
bm91Z2ggdG8gaG9sZCBhIHBvaW50ZXIgdG8gYW55IGRhdGEgaXRlbS4NCihUaGF0IGluIGl0c2Vs
ZiBpcyBwcm9ibGVtYXRpYyBmb3IgaW1wbGVtZW50YXRpb25zIHRoYXQNCmVuY29kZSBtdWx0aXBs
ZSBjaGFyYWN0ZXJzIGludG8gYSBtYWNoaW5lIHdvcmQgYW5kIG5lZWQNCnRvIHVzZSAnZmF0JyBw
b2ludGVycyBpbiBvcmRlciB0byBlbmNvZGUgdGhlIG9mZnNldC4pDQoNCglEYXZpZA0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
