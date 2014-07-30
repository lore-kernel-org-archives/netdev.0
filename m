From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] tcp: don't require root to read tcp_metrics
Date: Wed, 30 Jul 2014 21:38:26 +0400
Message-ID: <53D92D92.4090403@cogentembedded.com>
References: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org
To: Debabrata Banerjee <dbanerje@akamai.com>, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/30/2014 09:13 PM, Debabrata Banerjee wrote:

> commit d23ff701643a4a725e2c7a8ba2d567d39daa29ea introduced netlink support for

    Please also specify that commit's summary line in parens.

> the new tcp_metrics, however it restricted getting of tcp_metrics to root user
> only. This is a change from how these values could have been fetched when in
> the old route cache. Unless there's a legitimate reason to restrict the reading
> of these values it would be better if normal users could fetch them.

> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: linux-kernel@vger.kernel.org

    You need to sign off on the patch, else it couldn't be applied.

WBR, Sergei
