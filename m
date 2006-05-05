From: Andi Kleen <ak@suse.de>
Subject: Re: pci_enable_msix throws up error
Date: Fri, 5 May 2006 10:44:25 +0200
Message-ID: <200605051044.25646.ak@suse.de>
References: <DBFABB80F7FD3143A911F9E6CFD477B00BA5E264@hqemmail02.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ravinandan.arakali@neterion.com, linux-kernel@vger.kernel.org,
	"Ananda. Raju" <ananda.raju@neterion.com>, netdev@vger.kernel.org,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751059AbWEEJCk@vger.kernel.org>
To: "Ayaz Abdulla" <AAbdulla@nvidia.com>
In-Reply-To: <DBFABB80F7FD3143A911F9E6CFD477B00BA5E264@hqemmail02.nvidia.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 07:14, Ayaz Abdulla wrote:
> I noticed the same behaviour, i.e. can not use both MSI and MSIX without
> rebooting.
> 
> I had sent a message to the maintainer of the MSI/MSIX source a few
> months ago and got a response that they were working on fixing it. Not
> sure what the progress is on it.

The best way to make progress faster would be for someone like you
who needs it to submit a patch to fix it then.

-Andi
