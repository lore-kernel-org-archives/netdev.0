From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] RPC: killing RPC tasks races fixed
Date: Thu, 17 Mar 2011 20:04:31 +0300
Message-ID: <4D823F1F.6010500@parallels.com>
References: <20110317121638.15035.39410.stgit@localhost6.localdomain6>	 <1300366904.9654.13.camel@lade.trondhjem.org>	 <4D822C3C.9090100@parallels.com> <1300380254.28305.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"skinsbursky@openvz.org" <skinsbursky@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300380254.28305.1.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

17.03.2011 19:44, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
> Are you sure? Why would the 2.6.32 rhel kernel differ from the mainli=
ne
> 2.6.32 kernel in this respect?
>

Checked again and realized, that was wrong.
This set sequence is the same in 2.6.32 rhel, 2.6.32 and 2.6.38 kernels=
=2E

--=20
Best regards,
Stanislav Kinsbursky
