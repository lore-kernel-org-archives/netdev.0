From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: br_log_state() s/entering/entered/
Date: Thu, 08 Mar 2012 00:25:35 -0800 (PST)
Message-ID: <20120308.002535.1307528364263033103.davem@davemloft.net>
References: <20120307082514.6293.59158.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: paulius.zaleckas@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120307082514.6293.59158.stgit@localhost.localdomain>
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

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Wed, 07 Mar 2012 10:25:14 +0200

> When br_log_state() is reporting state it should say "entered"
> istead of "entering" since state at this point is already
> changed.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

Applied.
