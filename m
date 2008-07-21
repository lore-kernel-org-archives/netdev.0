From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] arptables in netns for real
Date: Mon, 21 Jul 2008 18:33:09 +0200
Message-ID: <4884BA45.0@trash.net>
References: <20080721162920.GD13264@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, den@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080721162920.GD13264@martell.zuzino.mipt.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> IN, FORWARD -- grab netns from in device,
> OUT -- from out device.

Applied, thanks.
