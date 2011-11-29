From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Tue, 29 Nov 2011 13:17:35 +0400
Message-ID: <4ED4A32F.90503@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
In-Reply-To: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Trond.
This is the final part of SUNRPC PipeFS virtualization.
I hope, that you'll find some time to review all series.

You can clone my working tree to have a look at what will be at the end:

git://github.com/skinsbursky/nfs-per-net-ns.git

BTW, I can provide a simple "sandbox" (a kind of container with it's own network 
namespace and veth device inside) which I use to test my changes.

-- 
Best regards,
Stanislav Kinsbursky
