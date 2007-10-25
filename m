From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6.25 patch] the planned eepro100 removal
Date: Thu, 25 Oct 2007 15:43:20 -0700
Message-ID: <47211C08.2040601@intel.com>
References: <20071024162440.GN30533@stusta.de> <4720FFAA.9080709@tmr.com> <47211A67.2090201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bill Davidsen <davidsen@tmr.com>, Adrian Bunk <bunk@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg
To: Jeff Garzik <jgarzik@pobox.com>, David Acker <dacker@roinet.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760376AbXJYWoA@vger.kernel.org>
In-Reply-To: <47211A67.2090201@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Bill Davidsen wrote:
>> Adrian Bunk wrote:
>>> This patch contains the planned removal of the eepro100 driver.
>>>
>> Are the e100 people satisfied that e100 now handles all known cases? I 
> 
> Nope.  There are still e100 work outstanding that means we cannot kill
> eepro100.

Agreed, there is still a receive unit hang in the last version that I got from
David Acker.

Auke
