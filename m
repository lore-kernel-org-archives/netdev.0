From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH 04/21] net: thunderx: Set queue count based on number of CPUs
Date: Thu, 11 Aug 2016 15:27:09 +0530
Message-ID: <CA+sq2CduEUujN_6BA9fOrFaW9XjzS-R01ZG7q2de3aUYDw2uwQ@mail.gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
 <1470811373-28277-5-git-send-email-sunil.kovvuri@gmail.com> <CO2PR11MB008837F849AB5891E076DF41971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Sunil Goutham <sgoutham@cavium.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR11MB008837F849AB5891E076DF41971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We have netif_get_num_default_rss_queues() which does this.
Thanks for pointing out the generic API.
Will make changes and resubmit.
