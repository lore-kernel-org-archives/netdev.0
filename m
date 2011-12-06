From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] SUNRPC: create svc_xprt in proper network namespace
Date: Tue, 06 Dec 2011 16:44:25 +0400
Message-ID: <4EDE0E29.9030804@parallels.com>
References: <20111206101910.1878.21798.stgit@localhost6.localdomain6> <20111206124427.GA12890@umich.edu>
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
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Jim Rees <rees@umich.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111206124427.GA12890@umich.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

06.12.2011 16:44, Jim Rees =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Stanislav Kinsbursky wrote:
>
>    This patch makes svc_xprt inherit network namespace link from it's=
 socket.
>
> Should be "its socket."

Yep, sure. Silly mistake.
Thanks.

--=20
Best regards,
Stanislav Kinsbursky
