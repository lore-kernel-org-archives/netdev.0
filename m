From: "Adolfo R. Brandes" <arbrandes@gmail.com>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Sat, 16 Feb 2008 07:41:12 -0200
Message-ID: <b4292e150802160141l5a9d36f5sbfeb3259678bffc0@mail.gmail.com>
References: <20080104034357.GA2113@atjola.homenet>
	 <b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
	 <20080107014638.GA4170@atjola.homenet>
	 <20080107.232355.228915298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: B.Steinbrink@gmx.de, bunk@kernel.org, andi@lisas.de,
	richie@coderworld.net, linux-kernel@vger.kernel.org,
	aabdulla@nvidia.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755709AbYBPJla@vger.kernel.org>
In-Reply-To: <20080107.232355.228915298.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jan 8, 2008 5:23 AM, David Miller <davem@davemloft.net> wrote:
> I am going to push this patch upstream, it is correct and we
> have a positive test case that failed before, so overall it's
> a net improvement even if we still don't exactly know why
> Adolfo's case still fails.

Sorry it took so long, but I got around to testing the patch properly,
i.e. same kernel on CK804 and MCP51, and it worked beautifully!
Thanks!

Adolfo
