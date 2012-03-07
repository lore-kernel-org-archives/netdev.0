From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] SUNRPC: set desired file system root before connecting
 local transports
Date: Wed, 07 Mar 2012 12:36:27 +0400
Message-ID: <4F571E0B.9060600@parallels.com>
References: <20120229145915.24030.31551.stgit@localhost6.localdomain6>	 <1331079588.10560.55.camel@lade.trondhjem.org> <1331079707.10560.56.camel@lade.trondhjem.org>
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
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331079707.10560.56.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

07.03.2012 04:21, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> BTW: We will in any case need Al Viro and Christoph's ACK in order to
> export the set_fs_root() function.

Yep, you right.
Is it better to add them into recipients on a reply to the patch or sen=
d the=20
patch once more?

--=20
Best regards,
Stanislav Kinsbursky
