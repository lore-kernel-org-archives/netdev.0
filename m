From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] preempt count regression w/ lockless loopback patch
Date: Tue, 22 Jun 2004 13:46:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0406221344380.1357620@neteng.engr.sgi.com>
References: <200406210510.i5L5A340018849@hera.kernel.org>
 <20040621035702.6114bdbe.akpm@osdl.org> <Pine.SGI.4.56.0406220913010.1334066@neteng.engr.sgi.com>
 <20040622123931.50d5ac05.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1072017398-688446164-1087937167=:1357620"
Cc: akpm@osdl.org, netdev@oss.sgi.com, chrisw@osdl.org, gillb4@telusplanet.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040622123931.50d5ac05.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1072017398-688446164-1087937167=:1357620
Content-Type: TEXT/PLAIN; charset=US-ASCII

On Tue, 22 Jun 2004, David S. Miller wrote:

> ....
> Can you instead give a patch relative to Andrew's?  His is
> applied already and in fact pushed into Linus's tree.
>

Yes. It is in the attachment.

--

Arthur
---1072017398-688446164-1087937167=:1357620
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="patch.rel_akpm"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.SGI.4.56.0406221346070.1357620@neteng.engr.sgi.com>
Content-Description: patch relative to akpm
Content-Disposition: attachment; filename="patch.rel_akpm"

LS0tIGxpbnV4LmFrcG0vZHJpdmVycy9uZXQvbG9vcGJhY2suYwkyMDA0LTA2
LTIyIDEzOjM1OjEzLjAwMDAwMDAwMCAtMDcwMA0KKysrIGxpbnV4L2RyaXZl
cnMvbmV0L2xvb3BiYWNrLmMJMjAwNC0wNi0yMiAxMzo0MjoyNy4wMDAwMDAw
MDAgLTA3MDANCkBAIC0xNzMsMTIgKzE3MywxMSBAQA0KIA0KIAkJaWYgKCFj
cHVfcG9zc2libGUoaSkpIA0KIAkJCWNvbnRpbnVlOw0KLQkJbGJfc3RhdHMg
PSAmcGVyX2NwdShsb29wYmFja19zdGF0cywgZ2V0X2NwdSgpKTsNCisJCWxi
X3N0YXRzID0gJnBlcl9jcHUobG9vcGJhY2tfc3RhdHMsIGkpOw0KIAkJc3Rh
dHMtPnJ4X2J5dGVzICAgKz0gbGJfc3RhdHMtPnJ4X2J5dGVzOw0KIAkJc3Rh
dHMtPnR4X2J5dGVzICAgKz0gbGJfc3RhdHMtPnR4X2J5dGVzOw0KIAkJc3Rh
dHMtPnJ4X3BhY2tldHMgKz0gbGJfc3RhdHMtPnJ4X3BhY2tldHM7DQogCQlz
dGF0cy0+dHhfcGFja2V0cyArPSBsYl9zdGF0cy0+dHhfcGFja2V0czsNCi0J
CXB1dF9jcHUoKTsNCiAJfQ0KIAkJCQkNCiAJcmV0dXJuIHN0YXRzOw0K

---1072017398-688446164-1087937167=:1357620--
