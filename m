From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next PATCH v3 6/8] net: ixgbe: add minimal parser details
 for ixgbe
Date: Wed, 17 Feb 2016 18:01:31 +0000
Message-ID: <80F0E864-49F7-4182-8CE5-C814C1A4DD43@intel.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051828.17139.51653.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_83B8B10A-D9CA-4834-B01B-18757CA540EA";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Jiri Pirko <jiri@resnulli.us>, "amir@vadai.me" <amir@vadai.me>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:40188 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423073AbcBQSCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 13:02:12 -0500
In-Reply-To: <20160217051828.17139.51653.stgit@john-Precision-Tower-5810>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_83B8B10A-D9CA-4834-B01B-18757CA540EA
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

John Fastabend <john.fastabend@gmail.com> wrote:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h  
> b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
> new file mode 100644
> index 0000000..43ebec4
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_model.h
> @@ -0,0 +1,112 @@
> +/*******************************************************************************
> + *
> + * Intel 10 Gigabit PCI Express Linux drive
> + * Copyright(c) 2013 - 2015 Intel Corporation.

Those copyright dates don't seem reasonable for a new file, since it  
clearly didn't exist in 2013. IANAL, but it has to be better to at least be  
accurate about when it was created.
--Apple-Mail=_83B8B10A-D9CA-4834-B01B-18757CA540EA--
