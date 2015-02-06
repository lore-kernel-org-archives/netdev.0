From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/3] orinoco: orinoco_plx use msecs_to_jiffies for conversion
Date: Fri,  6 Feb 2015 06:46:50 +0000 (UTC)
Message-ID: <20150206064650.46D22140C91@smtp.codeaurora.org>
References: <1423037261-20193-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benoit Taine <benoit.taine@lip6.fr>,
	Bjorn Helgaas <bhelgaas@google.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423037261-20193-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This is only an API consolidation and should make things more readable
> it replaces var * HZ / 1000 by msecs_to_jiffies(var).
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, 3 patches applied to wireless-drivers-next.git:

ab458cc85fa2 orinoco: orinoco_plx use msecs_to_jiffies for conversion
3427da4597ae orinoco: orinoco_pci use msecs_to_jiffies for conversion
c1f1f6663b3c orinoco: orinoco_tmd use msecs_to_jiffies for conversion

Kalle Valo
