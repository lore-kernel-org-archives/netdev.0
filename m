From: Daniel Drake <dsd@gentoo.org>
Subject: Re: pcnet32 devices with incorrect trident vendor ID
Date: Thu, 12 Jan 2006 21:03:17 +0000
Message-ID: <43C6C415.7030307@gentoo.org>
References: <20060112175051.GA17539@us.ibm.com> <43C6C0E6.7030705@gentoo.org> <20060112205714.GK19769@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, mulix@mulix.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161276AbWALVDd@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20060112205714.GK19769@parisc-linux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> It looks to me like there used to be a quirk that knew about this bug
> and fixed it.
> 
> The reason I say this is that the lspci -x dumps are the same -- both
> featuring the wrong vendor ID.

Good catch. I didn't notice this.

 > Want to dig through 2.4 and look for
> this quirk?

No time for this personally.

Daniel
