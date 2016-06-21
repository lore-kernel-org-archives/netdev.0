From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [alsa-devel] [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 21 Jun 2016 21:40:01 +0200
Message-ID: <20160621194001.GB2489@netboy>
References: <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
 <20160620121838.GA5257@localhost.localdomain>
 <07283da9-f6d1-c3b1-7989-a6fce7ca0ee6@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	Takashi Sakamoto <o-takashi@sakamocchi.jp>,
	Arnd Bergmann <arnd@linaro.org>, linux-media@vger.kernel.org
To: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <07283da9-f6d1-c3b1-7989-a6fce7ca0ee6@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2016 at 10:45:18AM -0700, Pierre-Louis Bossart wrote:
> You can experiment with the 'dma' and 'link' timestamps today on any
> HDaudio-based device. Like I said the synchronized part has not been
> upstreamed yet (delays + dependency on ART-to-TSC conversions that made it
> in the kernel recently)

Can you point me to any open source apps using the dma/link
timestamps?

Thanks,
Richard
