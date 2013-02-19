From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
 2013.02.16
Date: Tue, 19 Feb 2013 18:06:05 +0000
Message-ID: <87618083B2453E4A8714035B62D67992337C4C8D@FMSMSX102.amr.corp.intel.com>
References: <1361003616-3422-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130218.123700.1507921010708117768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Michal Miroslaw <mirqus@gmail.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57736 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758843Ab3BSSGj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:06:39 -0500
In-Reply-To: <20130218.123700.1507921010708117768.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g] On
>Behalf Of David Miller
>Sent: Monday, February 18, 2013 9:37 AM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Upd=
ates
>2013.02.16
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Sat, 16 Feb 2013 00:33:21 -0800
>
>> This series contains updates to e1000, e1000e, igb, igbvf and ixgbe.
>> The e1000, e1000e, igb and igbvf are single patch changes and the
>> remaining 11 patches are all against ixgbe.
> ...
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next ma=
ster
>
>Pulled.
>
>I trust that Emil will work out the I2C mutex locking issues being
>discussed with Micha=B3 Miros=B3aw wrt. patch #13.
>
>Thanks.

Thanks Dave, I will work on improving the I2C locking for sure.

Emil
