From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: loop on reset adapter with ixgbe
Date: Tue, 26 Nov 2013 18:47:41 +0000
Message-ID: <87618083B2453E4A8714035B62D679924FE8D806@FMSMSX105.amr.corp.intel.com>
References: <20131120182524.GC16953@gandi.net>
 <F6FB0E698C9B3143BDF729DF222866466FD88724@ORSMSX110.amr.corp.intel.com>
 <20131126130410.GD2849@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"Potenza, Leonardo" <leonardo.potenza@intel.com>
To: William Dauchy <william@gandi.net>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44843 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539Ab3KZSrz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 13:47:55 -0500
In-Reply-To: <20131126130410.GD2849@gandi.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Could you please send the complete output from dmesg along with the stats (ethtool -S) from the interface and also your .config from your kernel?

You can send the attachments directly to me or Don, or better yet open a bug at e1000.sf.net if possible.

Thanks,
Emil

>-----Original Message-----
>From: William Dauchy [mailto:william@gandi.net]
>Sent: Tuesday, November 26, 2013 5:04 AM
>To: Skidmore, Donald C
>Cc: William Dauchy; netdev@vger.kernel.org; Keller, Jacob E;
>Fastabend, John R; Tantilov, Emil S; Potenza, Leonardo
>Subject: Re: loop on reset adapter with ixgbe
>
>On Nov20 18:58, Skidmore, Donald C wrote:
>> I also just noticed your firmware looks in correct.  What
>is the DevID for your device?
>
>might be a stupid question, but which id are you talking
>about? How can
>I get it?
>
>> Likewise do you have another NIC and if so could you check
>it's firmware-version?
>
>I have some NIC with the same firmware without any problem.
>
>Regards,
>--
>William
