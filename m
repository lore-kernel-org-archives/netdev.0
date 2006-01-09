From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] ipw2100: support WEXT-18 enc_capa v2
Date: Mon, 09 Jan 2006 10:43:50 -0500
Message-ID: <43C284B6.8060909@pobox.com>
References: <1136820457.7941.4.camel@dhcp83-115.boston.redhat.com>	 <43C282A5.6010609@pobox.com> <1136821181.7941.9.camel@dhcp83-115.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, netdev@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net
Return-path: <ipw2100-devel-admin@lists.sourceforge.net>
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1136821181.7941.9.camel@dhcp83-115.boston.redhat.com>
Sender: ipw2100-devel-admin@lists.sourceforge.net
Errors-To: ipw2100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Hi,
> 
> This patch allows ipw2100 driver to advertise the WPA-related encryption
> options that it does really support.  It's necessary to work correctly
> with NetworkManager and other programs that actually check driver & card
> capabilities.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> 
> --- ipw2100.c.nowpa	2006-01-08 14:04:00.000000000 -0500
> +++ ipw2100.c	2006-01-08 15:47:37.000000000 -0500

Malformed patch:

Applying 'ipw2100: support WEXT-18 enc_capa v2'

error: ipw2100.c: does not exist in index

Please resend in correct format (applies with 'patch -sp1').

	Jeff




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
