From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] SUNRPC: create svc_xprt in proper network namespace
Date: Wed, 07 Dec 2011 12:45:16 +0400
Message-ID: <4EDF279C.1060501@parallels.com>
References: <20111206101910.1878.21798.stgit@localhost6.localdomain6> <20111206204851.GB12640@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111206204851.GB12640@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.12.2011 00:48, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Dec 06, 2011 at 02:19:10PM +0300, Stanislav Kinsbursky wrote:
>> This patch makes svc_xprt inherit network namespace link from it's s=
ocket.
>
> And poor rdma gets left out.

Sorry, but this is not a part of my interest.

> OK.  Applying for 3.3 (with changelog typo
> fixed).
>

Good, thanks.

--=20
Best regards,
Stanislav Kinsbursky
