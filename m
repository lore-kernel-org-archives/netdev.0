From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 13:28:41 -0600
Message-ID: <200502271328.41747.jdmason@us.ibm.com>
References: <42208D83.80803@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <42208D83.80803@phekda.gotadsl.co.uk>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 26 February 2005 08:53 am, Richard Dawe wrote:
> Hi Francois and Jon!
> 
> Please find attached a patch that adds the hardware statistics ethtool 
> operations to the r8169 driver. It's against 2.6.11-rc5.

I tested it on my amd64 system and it works great.  

I saw the same error if stats were gathered with the interface was down.  As 
a sanity check, I preformed the same test on e1000 and it does not have this 
error.  Not sure the significance of that.

Thanks Richard!

Jon
