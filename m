From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 01/26] drivers: isdn: Rectify typing error in xdi_msg.h
Date: Fri, 07 Feb 2014 21:48:55 +0300
Message-ID: <52F52A97.1010001@cogentembedded.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: Rashika Kheria <rashika.kheria@gmail.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/07/2014 03:18 PM, Rashika Kheria wrote:

> Rectify typing error while including the guard for the header
> file xdi_msg.h so that proper guard is wrapped around the file
> to prevent it from being included more than once.

> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
> Reviewed-by: Josh Triplett <josh@joshtriplett.org>

    You need to specify "eicon: " in the patch subjects, else there's an 
impression you're modifying the generic ISDN code instead of the concrete 
driver. You might as well drop "drivers:".

WBR, Sergei
