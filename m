From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] wimax: testing for rfkill support should also test
 for CONFIG_RFKILL_MODULE
Date: Thu, 08 Jan 2009 11:08:07 -0800 (PST)
Message-ID: <20090108.110807.103950637.davem@davemloft.net>
References: <cover.1231355768.git.inaky@linux.intel.com>
	<ce4d7f71df1471d502e02861a7db65cbb2a5548f.1231355768.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au, wimax@linuxwimax.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wimax@intel.com, linux-next@vger.kernel.org, greg@kroah.com
To: inaky@linux.intel.com
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <ce4d7f71df1471d502e02861a7db65cbb2a5548f.1231355768.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Wed,  7 Jan 2009 11:22:21 -0800

> Current WiMAX rfkill code is missing the case where rfkill is compiled
> in as modules and works only when rfkill is compiled in. This is not
> correct. Fixed to test for CONFIG_RFKILL or CONFIG_RKILL_MODULE.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied.
