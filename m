From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [Regression] [2.6.35-rc1] ssb_is_sprom_available
Date: Mon, 31 May 2010 14:53:00 -0600
Message-ID: <20100531205300.GB32708@parisc-linux.org>
References: <201005312155.20602.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-pci@vger.kernel.org, linux-usb@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>
To: Maciej Rutecki <maciej.rutecki@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201005312155.20602.maciej.rutecki@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 31, 2010 at 09:55:20PM +0200, Maciej Rutecki wrote:
> Last known good: 2.6.34
> Failing kernel: 2.6.35-rc1
> 
> subsystem: PCI, USB(?)
> 
> Kernel dies during booting on message "ssb_is_sprom_available", see picture:
> http://www.unixy.pl/maciek/download/kernel/2.6.35-rc1/gumis/DSC_0011.JPG

Um, looks like it's something to do with the Sonics Silicon Backplane,
not PCI, nor USB.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
