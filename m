From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] TNETW1450: successful device initialization
Date: Wed, 1 Feb 2006 11:55:49 +0200
Message-ID: <200602011155.49501.vda@ilport.com.ua>
References: <20060201085205.GA9315@rhlx01.fht-esslingen.de> <200602011120.15686.vda@ilport.com.ua> <1138786708.26656.4.camel@curcuma.ens.fr>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acx100-devel@lists.sourceforge.net,
	andi@lisas.de
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Jean-Baptiste Note <jean-baptiste.note@wanadoo.fr>
In-Reply-To: <1138786708.26656.4.camel@curcuma.ens.fr>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Wednesday 01 February 2006 11:38, Jean-Baptiste Note wrote:
> Hi Denis,
> 
> > Do you have a "HOWTO sniff USB under Windows" or URL to it?
> > May be helpful for other potential developers.
> > 
> 
> One page which I found very usefull for prism54softmac USB sniffing
> under windows is this one :
> 
> http://benoit.papillault.free.fr/usbsnoop/
> 
> Another very good way to snoop the USB frames is under linux if your
> driver happens to run under ndiswrapper (which is often the case),
> either by savage printk's, or by using the USB snooping facilities from
> Pete Zaitcev.

Added to acx README, thanks!
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
