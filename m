From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: ipsecv6 needs a space when printing
	audit record.
Date: Mon, 19 Mar 2007 18:47:49 -0700 (PDT)
Message-ID: <20070319.184749.85418422.davem@davemloft.net>
References: <200703200014.l2K0ExTL015802@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eparis@redhat.com, redhat-lspp@redhat.com
To: latten@austin.ibm.com
Return-path: <redhat-lspp-bounces@redhat.com>
In-Reply-To: <200703200014.l2K0ExTL015802@faith.austin.ibm.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Mon, 19 Mar 2007 18:14:59 -0600

> This patch adds a space between printing of the src and dst ipv6 addresses.
> Otherwise, audit or other test tools may fail to process the audit
> record properly because they cannot find the dst address.
> 
> Please let me know if this patch is ok. It is minor fix, but I have
> tested it and printing ipsecv6 audit record is much better.
> 
> Regards,
> Joy
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>
> 
> Patch is against linux-2.6.20-rc4.

Seems straightforward enough, applied, thanks Joy.
