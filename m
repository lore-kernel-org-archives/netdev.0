From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] act_mirred: do not drop packets when fails to mirror it
Date: Wed, 15 Aug 2012 08:35:41 -0400
Message-ID: <1345034141.20443.12.camel@mojatatu>
References: <20120815093756.22238.80872.stgit@amd-6168-8-1.englab.nay.redhat.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120815093756.22238.80872.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2012-08-15 at 17:37 +0800, Jason Wang wrote:
> We drop packet unconditionally when we fail to mirror it. This is not intended
> in some cases.

Hi Jason,
Did you actually notice the behavior you described or were you going by
the XXX comment I had in the code?

cheers,
jamal
