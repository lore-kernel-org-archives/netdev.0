From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VMXNET3: Check for map error in vmxnet3_set_mc
Date: Fri, 05 Sep 2014 11:50:53 -0700 (PDT)
Message-ID: <20140905.115053.660994166240082520.davem@davemloft.net>
References: <1409688824-32619-1-git-send-email-acking@vmware.com>
	<1409688824-32619-2-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	penguin-kernel@I-love.SAKURA.ne.jp
To: acking@vmware.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1409688824-32619-2-git-send-email-acking@vmware.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Andy King <acking@vmware.com>
Date: Tue,  2 Sep 2014 13:13:44 -0700

> We should check if the map of the table actually succeeds, and also free
> resources accordingly.
> 
> Version bumped to 1.2.1.0
> 
> Acked-by: Shelley Gong <shelleygong@vmware.com>
> Acked-by: Bhavesh Davda <bhavesh@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Applied, thanks.
