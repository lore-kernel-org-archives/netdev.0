From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Thu, 3 May 2012 00:31:29 +0300
Message-ID: <20120502213128.GB8266@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
 <20120502055008.GA29319@redhat.com>
 <20120502.024427.22049954455309204.davem@davemloft.net>
 <20120502081141.GA30549@redhat.com>
 <87pqammkvs.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87pqammkvs.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2012 at 12:40:55PM -0700, Eric W. Biederman wrote:
> 
> Side question.  Are you aware that macvtap/vhost net is broken
> in the presence of  vlan accelleration and that vlan accelleration
> is not optional if you are using vlan headers?
> 
> Eric

I didn't know. Could you explain please?
