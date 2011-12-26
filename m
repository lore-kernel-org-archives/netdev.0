From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v2 0/6] SUNPRC: cleanup PipeFS for network-namespace-aware
 users
Date: Mon, 26 Dec 2011 15:50:35 +0400
Message-ID: <4EF85F8B.6070004@parallels.com>
References: <20111226114042.13743.73804.stgit@localhost6.localdomain6>
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
In-Reply-To: <20111226114042.13743.73804.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Trond.
This patch set depend on
"SUNRPC: initial part of making pipefs work in net ns"
and
"SUNRPC: remove non-exclusive pipe creation from RPC pipefs"

I'm not sure about did you applied them already or not, so I've rebased and 
resent them too.

-- 
Best regards,
Stanislav Kinsbursky
