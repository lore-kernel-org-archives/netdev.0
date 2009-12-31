From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Thu, 31 Dec 2009 10:24:41 -0800
Message-ID: <20091231102441.6e81598a@nehalam>
References: <4B300A2A.8040305@gmail.com>
	<4B300E30.9090707@majjas.com>
	<4B3114E3.1070602@majjas.com>
	<4B329FA3.9090904@majjas.com>
	<20091223230102.4bb0100e.akpm@linux-foundation.org>
	<4B34E847.8010809@majjas.com>
	<20091225152200.1cf11dfe@nehalam>
	<4B3581C7.8000702@majjas.com>
	<20091226095723.7ac82b18@nehalam>
	<4B367409.5060202@majjas.com>
	<4B379378.4000102@majjas.com>
	<20091227102238.0df149f9@nehalam>
	<4B37B7E2.5070307@majjas.com>
	<20091229093023.3ad24786@nehalam>
	<4B3A5048.9090700@majjas.com>
	<20091229114938.1f4d1c5c@nehalam>
	<4B3AFFE8.3060409@majjas.com>
	<20091229235942.51bf733d@nehalam>
	<4B3B7488.6080503@majjas.com>
	<20091230101046.2816d545@nehalam>
	<4B3CE8CA.5050003@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752668AbZLaSZG@vger.kernel.org>
In-Reply-To: <4B3CE8CA.5050003@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have similar motherboards and ACPI is having issues with parsing
the tables, probably not related but see:

  http://bugzilla.kernel.org/show_bug.cgi?id=14954


-- 
