From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Thu, 31 Mar 2005 08:35:15 -0700
Message-ID: <20050331153515.GA19219@colo.lackof.org>
References: <20050330161522.GH32111@g5.random> <20050331114122.GL24804@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Aizman <itn780@yahoo.com>, open-iscsi@googlegroups.com,
        "'jamal'" <hadi@cyberus.ca>, "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        "'Rik van Riel'" <riel@redhat.com>, mpm@selenic.com,
        michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050331114122.GL24804@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 01:41:22PM +0200, Andi Kleen wrote:
> It wont work - I can guarantee you that if you add a limit like
> "we only support 8 iscsi connections max" then users/customers will raise
> hell because it does not fit their networks.

HP has been doing that for years (decades?) for parallel SCSI
in "High Availability Configuration Guides". It lays out exactly
what is and isn't supported. I'm sure other vendors have similar
restrictions. As long as the product is still reasonably useful
and the vendor provides a solid assurance it will work, such
configuration restrictions are quite acceptable.

I'm NOT arguing "8 iSCSI connections max" is reasonable or enough.
I just arguing some sort of limit is acceptable.

grant
