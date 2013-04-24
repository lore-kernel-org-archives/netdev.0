From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: getting VF link info seems to be broken in 3.9-rc8
Date: Wed, 24 Apr 2013 19:45:34 +0300
Message-ID: <51780C2E.9090201@mellanox.com>
References: <5177D946.9080704@mellanox.com> <20130424083825.00004f94@unknown> <20130424090133.00005ca6@unknown> <A3A921390EAE4044940E99EBF13D97322426359F@FMSMSX104.amr.corp.intel.com> <517809A4.3070001@mellanox.com> <A3A921390EAE4044940E99EBF13D973224263635@FMSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>, Rony Efraim <ronye@mellanox.com>
To: "Li, Sibai" <sibai.li@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog125.obsmtp.com ([207.126.144.159]:52033 "EHLO
	eu1sys200aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754934Ab3DXQpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:45:53 -0400
In-Reply-To: <A3A921390EAE4044940E99EBF13D973224263635@FMSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/2013 19:44, Li, Sibai wrote:
> This means that the VF driver is loaded before the PF is loaded. Did you reload the VF after the PF is loaded?
I have reloaded the VF driver now and it didn't make any difference
