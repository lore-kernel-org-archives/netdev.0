From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: make some functions and variables static
Date: Tue, 17 Jan 2012 10:04:56 -0500 (EST)
Message-ID: <20120117.100456.580601879746362569.davem@davemloft.net>
References: <1326477992-16229-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326477992-16229-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Fri, 13 Jan 2012 16:06:32 -0200

> Some functions and variables in ehea are only used in their own file, so
> they should be static. One particular function had a very generic name,
> print_error_data.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied, thanks.
