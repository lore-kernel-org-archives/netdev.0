From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: mdb: start delete timer for temp
 static entries
Date: Wed, 08 Jul 2015 14:53:17 -0700 (PDT)
Message-ID: <20150708.145317.1856923513879691253.davem@davemloft.net>
References: <1436187215-4973-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	amwang@redhat.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1436187215-4973-1-git-send-email-nikolay@cumulusnetworks.com>
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
Date: Mon,  6 Jul 2015 05:53:35 -0700

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> Start the delete timer when adding temp static entries so they can expire.
> 
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: ccb1c31a7a87 ("bridge: add flags to distinguish permanent mdb entires")

Applied, thanks.
