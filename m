From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH RESENT] staging: r8188eu: Move writeN buffer off stack
Date: Sat, 19 Oct 2013 14:12:03 +0300
Message-ID: <20131019111203.GN11731@mwanda>
References: <5261AA78.6090205@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev <netdev@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <5261AA78.6090205@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 18, 2013 at 04:39:04PM -0500, Larry Finger wrote:
> The driver places a 254-byte buffer on the stack when writing long output.
> To reduce stack usage, a buffer of the required length is acquired using
> kmemdup().
> 

The patch is badly whitespace dammaged.

regards,
dan carpenter
