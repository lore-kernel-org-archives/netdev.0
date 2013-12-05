From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data
 in code executed on non-rx_handler path
Date: Thu, 05 Dec 2013 07:37:06 -0800
Message-ID: <1386257826.30495.196.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jtluka@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	edumazet@google.com, laine@redhat.com, zhiguohong@tencent.com,
	davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
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

On Thu, 2013-12-05 at 16:27 +0100, Jiri Pirko wrote:

> RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
> 
> Reported-by: Laine Stump <laine@redhat.com>
> Debugged-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks
