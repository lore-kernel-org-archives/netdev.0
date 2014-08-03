From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] cris: fix %d confusingly prefixed with
 0x in format string
Date: Sat, 02 Aug 2014 23:10:15 -0700
Message-ID: <1407046215.1835.24.camel@joe-AO725>
References: <1407018043-648-1-git-send-email-hans@hanshq.net>
 <1407026806.1835.21.camel@joe-AO725> <53DD8E17.1@hanshq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel <devel@driverdev.osuosl.org>, linux-cifs@vger.kernel.org,
 alsa-devel@alsa-project.org, linux-cris-kernel@axis.com,
 netdev <netdev@vger.kernel.org>,
 kernel-janitors <kernel-janitors@vger.kernel.org>,
 linux-kernel@vger.kernel.org, starvik@axis.com
To: Hans Wennborg <hans@hanshq.net>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <53DD8E17.1@hanshq.net>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Sat, 2014-08-02 at 18:19 -0700, Hans Wennborg wrote:
> Yes, I have a patch for a bunch of these, but I figured it would be 
> easier to get it merged if I split it up. (Complete kernel newbie here.)

You as a kernel newbie did good, thanks.

A small tip would be to do all of them in a single series
cc'ing each individual patch to the appropriate maintainers
and mailing lists.

cheers, Joe
