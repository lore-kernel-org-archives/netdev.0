From: Clemens Brunner <clemens.brunner@tugraz.at>
Subject: Re: r8169: Link always down
Date: Tue, 29 May 2007 10:46:50 +0200
Message-ID: <465BE87A.3050809@tugraz.at>
References: <46557430.5060501@tugraz.at> <20070524120644.GA7224@electric-eye.fr.zoreil.com> <46569CF4.2030108@tugraz.at> <20070527222024.GA15066@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay.tu-graz.ac.at ([129.27.2.202]:58099 "EHLO
	mailrelay.tugraz.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbXE2IrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2007 04:47:03 -0400
In-Reply-To: <20070527222024.GA15066@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> [...]
 > As an option you can retrieve the url below which contains all the patches
> above in a single patch-file:
> http://www.fr.zoreil.com/people/francois/misc/20070522-2.6.22-rc2-r8169.patch

Thanks for providing the single patch file. I was able to compile the patched 
kernel (version 2.6.22-rc3) with the EEPROM option enabled. However, the NIC 
still does not work (r8169: eth0: link down). Please let me know what else I 
could do to help you.

Clemens
