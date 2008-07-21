From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 04/31 DO NOT APPLY] enable netfilter in netns
Date: Mon, 21 Jul 2008 19:01:32 +0200
Message-ID: <4884C0EC.80204@trash.net>
References: <20080721163358.GH13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080721163358.GH13264@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> 	Only for testing.

Thanks for posting this, I'll try to get this reviewed and
merged before the merge window closes.

Just one question since this patch is marked DO NO APPLY -
are the remaining patches meant for applying? Is there
any further work left until netfilter is fully namespace
aware?

