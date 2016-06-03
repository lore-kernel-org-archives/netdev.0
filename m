From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
Date: Fri, 3 Jun 2016 11:00:36 +1000 (AEST)
Message-ID: <alpine.LRH.2.20.1606031100260.18314@namei.org>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com> <20160508.235620.333454221783238471.davem@davemloft.net> <573B271B.30202@canonical.com> <57505F34.5020609@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
To: Tyler Hicks <tyhicks@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57505F34.5020609@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Jun 2016, Tyler Hicks wrote:

> On 05/17/2016 09:13 AM, Tyler Hicks wrote:
> > On 05/08/2016 10:56 PM, David Miller wrote:
> >> From: Tyler Hicks <tyhicks@canonical.com>
> >> Date: Fri,  6 May 2016 18:04:12 -0500
> >>
> >>> This pair of patches does away with what I believe is a useless denial
> >>> audit message when a privileged process initially accesses a net sysctl.
> >>
> >> The LSM folks can apply this if they agree with you.
> > 
> > Hi James - Could you pick up these two bug fix patches? Thanks!
> 
> Hello - Just checking in again to see if you plan on taking these
> through the security tree?

Sure, please resend.

-- 
James Morris
<jmorris@namei.org>
