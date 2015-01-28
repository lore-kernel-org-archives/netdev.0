From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: cxgb4:  CONFIG_CXGB4_DCB?
Date: Wed, 28 Jan 2015 22:35:16 +0100
Message-ID: <1422480916.3621.53.camel@x220>
References: <1422431914.5666.7.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Valentin Rothberg <valentinrothberg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422431914.5666.7.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[resend because netdev and linux-kernel were down the first time.]

On Wed, 2015-01-28 at 08:58 +0100, Paul Bolle wrote:
> Your commit dc9daab226aa ("cxgb4: Added support in debugfs to dump
> sge_qinfo") is included in today's linux-next (ie, next-20150128). I
> noticed because a script I use to check linux-next spotted a problem
> with it.
> 
> It added a preprocessor check for CONFIG_CXGB4_DCB. There's no Kconfig
> symbol CXGB4_DCB. I guess a check for CONFIG_CHELSIO_T4_DCB was actually
> intended.
> 
> Thanks,
> 
> 
> Paul Bolle
