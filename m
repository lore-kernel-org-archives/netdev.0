From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/5] bpf: security: New file mode and LSM
 hooks for eBPF object permission control
Date: Sat, 14 Oct 2017 11:27:53 -0700 (PDT)
Message-ID: <20171014.112753.925194737261973271.davem@davemloft.net>
References: <20171012205510.36028-1-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, jeffv@google.com,
        alexei.starovoitov@gmail.com, lorenzo@google.com,
        daniel@iogearbox.net, sds@tycho.nsa.gov, james.l.morris@oracle.com,
        paul@paul-moore.com, fengc@google.com
To: chenbofeng.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbdJNS1y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:27:54 -0400
In-Reply-To: <20171012205510.36028-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpIbW1tLCB0aGlzIGRvZXNuJ3QgYnVpbGQgZm9yIG1lOg0KDQpzZWN1cml0eS9zZWxpbnV4L2hv
b2tzLmM6IEluIGZ1bmN0aW9uIKFicGZfZmRfcGFzc6I6DQpzZWN1cml0eS9zZWxpbnV4L2hvb2tz
LmM6NjMyNTo0MDogZXJyb3I6IKFTRUNDTEFTU19CUEZfTUFQoiB1bmRlY2xhcmVkIChmaXJzdCB1
c2UgaW4gdGhpcyBmdW5jdGlvbik7IGRpZCB5b3UgbWVhbiChU0VDQ0xBU1NfQlBGoj8NCiAgIHJl
dCA9IGF2Y19oYXNfcGVybShzaWQsIGJwZnNlYy0+c2lkLCBTRUNDTEFTU19CUEZfTUFQLA0KICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIF5+fn5+fn5+fn5+fn5+fn4NCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBTRUNDTEFTU19CUEYNCnNlY3Vy
aXR5L3NlbGludXgvaG9va3MuYzo2MzI1OjQwOiBub3RlOiBlYWNoIHVuZGVjbGFyZWQgaWRlbnRp
ZmllciBpcyByZXBvcnRlZCBvbmx5IG9uY2UgZm9yIGVhY2ggZnVuY3Rpb24gaXQgYXBwZWFycyBp
bg0Kc2VjdXJpdHkvc2VsaW51eC9ob29rcy5jOjYzMzI6NDA6IGVycm9yOiChU0VDQ0xBU1NfQlBG
X1BST0eiIHVuZGVjbGFyZWQgKGZpcnN0IHVzZSBpbiB0aGlzIGZ1bmN0aW9uKTsgZGlkIHlvdSBt
ZWFuIKFTRUNDTEFTU19CUEZfTUFQoj8NCiAgIHJldCA9IGF2Y19oYXNfcGVybShzaWQsIGJwZnNl
Yy0+c2lkLCBTRUNDTEFTU19CUEZfUFJPRywNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICBefn5+fn5+fn5+fn5+fn5+fg0KICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIFNFQ0NMQVNTX0JQRl9NQVANCg==
