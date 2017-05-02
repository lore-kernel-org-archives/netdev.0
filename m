From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipx: call ipxitf_put() in ioctl error path
Date: Tue, 02 May 2017 15:35:11 -0400 (EDT)
Message-ID: <20170502.153511.1670530060500505666.davem@davemloft.net>
References: <143C0AFC63FC204CB0C55BB88F3A8ABB33419ED1@EX02.corp.qihoo.net>
        <20170502105853.yz3ny6lyso6isdvx@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, security@kernel.org, secalert@redhat.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53376 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdEBTfN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:35:13 -0400
In-Reply-To: <20170502105853.yz3ny6lyso6isdvx@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPg0KRGF0ZTogVHVl
LCAyIE1heSAyMDE3IDEzOjU4OjUzICswMzAwDQoNCj4gV2Ugc2hvdWxkIGNhbGwgaXB4aXRmX3B1
dCgpIGlmIHRoZSBjb3B5X3RvX3VzZXIoKSBmYWlscy4NCj4gDQo+IFJlcG9ydGVkLWJ5OiDmnY7l
vLogPGxpcWlhbmc2LXNAMzYwLmNuPg0KPiBTaWduZWQtb2ZmLWJ5OiBEYW4gQ2FycGVudGVyIDxk
YW4uY2FycGVudGVyQG9yYWNsZS5jb20+DQoNCkFwcGxpZWQsIHRoYW5rcyBEYW4uDQo=
