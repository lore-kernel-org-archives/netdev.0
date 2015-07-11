From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: mdb: allow the user to delete mdb
 entry if there's a querier
Date: Fri, 10 Jul 2015 18:18:14 -0700 (PDT)
Message-ID: <20150710.181814.1446975476992171500.davem@davemloft.net>
References: <1436440365-909-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1436440365-909-1-git-send-email-nikolay@cumulusnetworks.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu,  9 Jul 2015 04:12:45 -0700

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> Until now when a querier was present static entries couldn't be deleted.
> Fix this and allow the user to manipulate the mdb with or without a
> querier.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
