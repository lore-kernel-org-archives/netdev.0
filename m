From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [REGRESSION][BISECTED] skge: add dma_mapping check
Date: Tue, 24 Sep 2013 11:16:58 -0400
Message-ID: <5241ACEA.6010402@canonical.com>
References: <1379494844.2294.12.camel@ThinkPad-X230.localdomain>	 <20130918220819.GA11989@electric-eye.fr.zoreil.com> <1379581391.2403.5.camel@ThinkPad-X230.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, member graysky <graysky@archlinux.us>,
	Greg KH <gregkh@linuxfoundation.org>
To: Igor Gnatenko <i.gnatenko.brain@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>, mpatocka@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379581391.2403.5.camel@ThinkPad-X230.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2013 05:03 AM, Igor Gnatenko wrote:
> Please, send patch.
>
The patch is in mainline as of 3.12-rc2 as commit:

Author: Mikulas Patocka <mpatocka@redhat.com>
Date:   Thu Sep 19 14:13:17 2013 -0400

    skge: fix broken driver

I don't see that the commit was Cc'd to stable.  Mikulas, we might need
to send a request directly to the stable maintainers and reqeust that
the commit be pulled into stable, in case they didn't notice the request
in the commit message.
