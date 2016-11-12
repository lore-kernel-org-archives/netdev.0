From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: ss: escape all null bytes in abstract unix
 domain socket
Date: Sat, 12 Nov 2016 10:17:29 +0300
Message-ID: <20161112101729.4d400929@samsung9>
References: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Isaac Boukris <iboukris@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477768820-1295-1-git-send-email-iboukris@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Oct 2016 22:20:19 +0300
Isaac Boukris <iboukris@gmail.com> wrote:

> Abstract unix domain socket may embed null characters,
> these should be translated to '@' when printed by ss the
> same way the null prefix is currently being translated.
> 
> Signed-off-by: Isaac Boukris <iboukris@gmail.com>

Applied
