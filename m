From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH net 0/4] update ipvs sysctl document
Date: Fri, 17 Feb 2017 14:33:57 +0800
Message-ID: <1487313241-11361-1-git-send-email-liuhangbin@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: lvs-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix and add some new ipvs sysctl options. Also use tab instead of whitespaces
to indent the descriptions.

Hangbin Liu (4):
  ipvs: fix sync_threshold description and add sync_refresh_period,
    sync_retries
  ipvs: Document sysctl sync_qlen_max and sync_sock_size
  ipvs: Document sysctl sync_ports
  ipvs: Document sysctl pmtu_disc

 Documentation/networking/ipvs-sysctl.txt | 68 ++++++++++++++++++++++++++++----
 1 file changed, 60 insertions(+), 8 deletions(-)

-- 
2.5.5

