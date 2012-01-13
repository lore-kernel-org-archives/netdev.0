From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v5 0/6] SUNRPC: rcbind clients virtualization
Date: Fri, 13 Jan 2012 14:03:39 +0400
Message-ID: <4F10017B.3070808@parallels.com>
References: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

13.01.2012 12:52, Stanislav Kinsbursky =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> This patch-set was created in context of clone of git branch:
> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> head: devel
>
> v5:
> 1) Rebased on up-to-date state ("devel" head).
> 2) Added two more patches from latter series ("SUNRPC: register servi=
ces with
> per-net rpcbind"), because logically this series is the more suitable=
 place for
> them.

Three patches from "SUNRPC: register services with per-net rpcbind" ser=
ies:
a) [1/7] "SUNRPC: create rpcbind client in passed network namespace con=
text"
b) [2/7] "SUNRPC: register rpcbind programs in passed network namespase=
 context"
c) [4/7] "SUNRPC: parametrize local rpcbind clients creation with net n=
s"

--=20
Best regards,
Stanislav Kinsbursky
