From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] Lockd: pass network namespace to creation and destruction
 routines
Date: Thu, 29 Mar 2012 18:36:24 +0400
Message-ID: <4F747368.3040509@parallels.com>
References: <20120329142209.20506.43224.stgit@localhost6.localdomain6>
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
In-Reply-To: <20120329142209.20506.43224.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch has a flaw. Thus will be v2.
Sorry.

-- 
Best regards,
Stanislav Kinsbursky
