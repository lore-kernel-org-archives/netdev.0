From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-acpi] [V4 PATCH 1/6] ACPI / scan: Parse _CCA and setup device coherency
Date: Thu, 21 May 2015 15:24:02 +0200
Message-ID: <3038248.bRme3FQvei@wuerfel>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com> <5074701.G8z7gpKvin@wuerfel> <20150521130116.GJ29424@e104818-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	herbert@gondor.apana.org.au, rjw@rjwysocki.net,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, bhelgaas@google.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lenb@kernel.org
To: linaro-acpi@lists.linaro.org
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20150521130116.GJ29424@e104818-lin.cambridge.arm.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 May 2015 14:01:16 Catalin Marinas wrote:
> On Wed, May 20, 2015 at 02:04:02PM +0200, Arnd Bergmann wrote:
> > On Wednesday 20 May 2015 06:52:03 Suravee Suthikulanit wrote:
> > > 
> > > Ok. That seems to be what Arnd would prefer as well.  Let's just leave 
> > > the support for _CCA=0 out until it is needed then.
> > 
> > Yes, that would be best (as I said repeatedly  )
> 
> I'm sure it won't be long before someone asks for this feature ;).

If nothing else, we get to publically shame them for building crappy
hardware then ;-)

	Arnd
